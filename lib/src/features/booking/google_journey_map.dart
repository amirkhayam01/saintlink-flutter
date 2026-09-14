import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/env.dart';
import '../../core/theme.dart';
import '../../domain/place.dart';
import 'journey_draft.dart';

/// Uses the same browser Maps/Directions APIs and origin as the website.
/// Only a public, referrer-restricted browser key is supplied by the platform.
class GoogleJourneyMap extends StatefulWidget {
  const GoogleJourneyMap({
    super.key,
    required this.journey,
    this.interactive = false,
    this.topPadding = 0,
  });
  final JourneyDraft journey;
  final bool interactive;
  final int topPadding;

  @override
  State<GoogleJourneyMap> createState() => _GoogleJourneyMapState();
}

class _GoogleJourneyMapState extends State<GoogleJourneyMap> {
  WebViewController? _web;
  String? _error;
  bool _ready = false;
  Timer? _timeout;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(GoogleJourneyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey.pickup != widget.journey.pickup ||
        oldWidget.journey.dropoff != widget.journey.dropoff ||
        !listEquals(oldWidget.journey.via, widget.journey.via) ||
        oldWidget.topPadding != widget.topPadding ||
        oldWidget.interactive != widget.interactive) {
      _load();
    }
  }

  Future<void> _load() async {
    final revision = ++_revision;
    _timeout?.cancel();
    _ready = false;
    _error = null;
    try {
      if (WebViewPlatform.instance == null) {
        throw MissingPluginException();
      }
      const definedKey = String.fromEnvironment('GOOGLE_MAPS_BROWSER_KEY');
      final key = definedKey.isNotEmpty
          ? definedKey
          : await const MethodChannel('uk.co.saintslink/maps')
                    .invokeMethod<String>('browserKey') ??
                '';
      if (!mounted || revision != _revision) return;
      if (key.isEmpty) throw MissingPluginException();
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0xFFEAF0EF));
      await controller.addJavaScriptChannel(
        'JourneyMap',
        onMessageReceived: (message) {
          if (!mounted || revision != _revision) return;
          _timeout?.cancel();
          if (message.message == 'ready') {
            debugPrint('Journey map ready');
            setState(() => _ready = true);
          } else {
            setState(() => _error = 'Route preview unavailable');
          }
        },
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (mounted &&
                revision == _revision &&
                error.isForMainFrame == true) {
              setState(() => _error = 'Map could not load');
            }
          },
          onNavigationRequest: (request) =>
              request.url == '${Env.websiteUrl}/' ||
                  request.url == 'about:blank'
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      );
      await controller.loadHtmlString(
        journeyMapHtml(
          widget.journey,
          key: key,
          interactive: widget.interactive,
          topPadding: widget.topPadding,
        ),
        baseUrl: '${Env.websiteUrl}/',
      );
      if (!mounted || revision != _revision) return;
      setState(() => _web = controller);
      _timeout = Timer(const Duration(seconds: 25), () {
        if (mounted && revision == _revision && !_ready) {
          setState(() => _error = 'Map could not load');
        }
      });
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(() => _error = 'Route preview unavailable');
      }
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFFEAF0EF)),
      if (_web != null)
        IgnorePointer(
          ignoring: !widget.interactive,
          child: WebViewWidget(
            controller: _web!,
            gestureRecognizers: widget.interactive
                ? {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  }
                : const {},
          ),
        ),
      if (!_ready || _error != null)
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: widget.topPadding.toDouble()),
            child: _error == null
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Material(
                    color: const Color(0xEEFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {});
                        _load();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: AppTheme.midnight,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Retry map',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.midnight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
    ],
  );
}

/// Serialise customer text as data, never as HTML or executable JavaScript.
String journeyMapHtml(
  JourneyDraft journey, {
  required String key,
  required bool interactive,
  required int topPadding,
}) {
  Object location(PlaceSelection place) {
    // Prefer the exact Google place to an ambiguous postal address.
    if (place.placeId != null && place.placeId!.isNotEmpty) {
      return {'placeId': place.placeId};
    }
    if (place.isLocated) return {'lat': place.latitude, 'lng': place.longitude};
    return place.address;
  }

  final stops = [
    journey.pickup,
    ...journey.via.where((p) => !p.isEmpty),
    journey.dropoff,
  ];
  final config = jsonEncode({
    'stops': stops.map(location).toList(),
    'interactive': interactive,
    'topPadding': topPadding,
  }).replaceAll('<', r'\u003c');
  final scriptUrl = Uri.https('maps.googleapis.com', '/maps/api/js', {
    'key': key,
    'callback': 'initMap',
    'loading': 'async',
    'v': 'weekly',
  }).toString();
  return '''<!doctype html><html><head>
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1">
<meta name="referrer" content="strict-origin-when-cross-origin">
<style>html,body,#map{height:100%;width:100%;margin:0;padding:0;background:#eaf0ef}</style>
</head><body><div id="map"></div><script>
const config=$config;
function notify(message){JourneyMap.postMessage(message);}
window.gm_authFailure=()=>notify('error');
window.initMap=async function(){
 try {
  const map=new google.maps.Map(document.getElementById('map'),{
   center:{lat:51.15,lng:-1},zoom:8,maxZoom:17,mapTypeId:'roadmap',
   isFractionalZoomEnabled:true,
   disableDefaultUI:true,zoomControl:config.interactive,
   gestureHandling:config.interactive?'greedy':'none',
   clickableIcons:false,keyboardShortcuts:false
  });
  const result=await new google.maps.DirectionsService().route({
   origin:config.stops[0],destination:config.stops[config.stops.length-1],
   waypoints:config.stops.slice(1,-1).map(location=>({location,stopover:true})),
   travelMode:google.maps.TravelMode.DRIVING
  });
  // White casing under a slim midnight line keeps the route legible over
  // both green countryside and dense grey city tiles.
  for(const line of [{strokeColor:'#ffffff',strokeWeight:6},{strokeColor:'#020617',strokeWeight:3}]){
   new google.maps.DirectionsRenderer({map,directions:result,
    preserveViewport:true,suppressInfoWindows:true,suppressMarkers:true,
    polylineOptions:{...line,strokeOpacity:1}
   });
  }
  const svg=body=>({url:'data:image/svg+xml;charset=UTF-8,'+encodeURIComponent(body)});
  const pickupIcon={...svg('<svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 26 26"><circle cx="13" cy="13" r="11" fill="#020617" stroke="#ffffff" stroke-width="3"/><circle cx="13" cy="13" r="4" fill="#facc15"/></svg>'),
   scaledSize:new google.maps.Size(26,26),anchor:new google.maps.Point(13,13)};
  const viaIcon={...svg('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><circle cx="8" cy="8" r="6" fill="#ffffff" stroke="#020617" stroke-width="3"/></svg>'),
   scaledSize:new google.maps.Size(16,16),anchor:new google.maps.Point(8,8)};
  const dropoffIcon={...svg('<svg xmlns="http://www.w3.org/2000/svg" width="34" height="44" viewBox="0 0 34 44"><path d="M17 2C9 2 3 8 3 16c0 10 14 26 14 26s14-16 14-26c0-8-6-14-14-14z" fill="#020617" stroke="#ffffff" stroke-width="3"/><circle cx="17" cy="16" r="5.5" fill="#facc15"/></svg>'),
   scaledSize:new google.maps.Size(34,44),anchor:new google.maps.Point(17,42)};
  const legs=result.routes[0].legs;
  const points=[legs[0].start_location,...legs.map(leg=>leg.end_location)];
  points.forEach((position,i)=>new google.maps.Marker({map,position,clickable:false,
   icon:i===0?pickupIcon:i===points.length-1?dropoffIcon:viaIcon,
   zIndex:i===points.length-1?3:i===0?2:1}));
  google.maps.event.addListenerOnce(map,'tilesloaded',()=>notify('ready'));
  const fitRoute=()=>map.fitBounds(result.routes[0].bounds,{
   top:config.topPadding+12,right:20,bottom:28,left:20
  });
  fitRoute();
  window.addEventListener('resize',fitRoute);
 }catch(error){notify('error');}
};
</script><script async src="$scriptUrl" onerror="notify('error')"></script></body></html>''';
}
