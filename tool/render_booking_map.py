"""Render the bundled regional overview from public-domain Natural Earth data.

Requires Pillow and pyshp. Bounds/projection match BookingMapImage in Flutter.
Source: https://www.naturalearthdata.com/about/terms-of-use/
"""
import io
import math
from pathlib import Path
import urllib.request
import zipfile

from PIL import Image, ImageDraw, ImageFont
import shapefile

WIDTH, HEIGHT = 1400, 900
WEST, EAST, SOUTH, NORTH = -3.6, 1.6, 50.25, 52.15


def mercator(latitude):
    return math.asinh(math.tan(math.radians(latitude)))


def project(point):
    longitude, latitude = point[:2]
    return (
        (longitude - WEST) / (EAST - WEST) * WIDTH,
        (mercator(NORTH) - mercator(latitude))
        / (mercator(NORTH) - mercator(SOUTH)) * HEIGHT,
    )


def shapes(layer, category):
    url = f'https://naturalearth.s3.amazonaws.com/10m_{category}/ne_10m_{layer}.zip'
    with urllib.request.urlopen(url, timeout=60) as response:
        archive = zipfile.ZipFile(io.BytesIO(response.read()))
    stem = f'ne_10m_{layer}'
    reader = shapefile.Reader(
        shp=io.BytesIO(archive.read(f'{stem}.shp')),
        shx=io.BytesIO(archive.read(f'{stem}.shx')),
        dbf=io.BytesIO(archive.read(f'{stem}.dbf')),
    )
    for shape in reader.iterShapes():
        left, bottom, right, top = shape.bbox
        if left > EAST or right < WEST or bottom > NORTH or top < SOUTH:
            continue
        parts = list(shape.parts) + [len(shape.points)]
        for start, end in zip(parts, parts[1:]):
            yield [project(point) for point in shape.points[start:end]]


def main():
    image = Image.new('RGB', (WIDTH, HEIGHT), '#dcebef')
    draw = ImageDraw.Draw(image)
    for polygon in shapes('land', 'physical'):
        draw.polygon(polygon, fill='#f3f2e9', outline='#cddbd5')
    for road in shapes('roads', 'cultural'):
        draw.line(road, fill='#e5d8ae', width=4)
        draw.line(road, fill='#fffdf7', width=2)
    font = ImageFont.truetype('assets/fonts/Figtree-500.ttf', 24)
    cities = [
        ('Southampton', -1.404, 50.909), ('London', -.128, 51.507),
        ('Bournemouth', -1.88, 50.72), ('Portsmouth', -1.09, 50.8),
        ('Winchester', -1.31, 51.06), ('Reading', -.97, 51.45),
        ('Oxford', -1.26, 51.75), ('Bath', -2.36, 51.38),
        ('Brighton', -.14, 50.82), ('Salisbury', -1.8, 51.07),
    ]
    for name, longitude, latitude in cities:
        x, y = project((longitude, latitude))
        draw.ellipse((x-3, y-3, x+3, y+3), fill='#8d9997')
        draw.text((x+8, y-14), name, fill='#6b7776', font=font)
    output = Path('assets/maps/southern_england.png')
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output, optimize=True)


if __name__ == '__main__':
    main()
