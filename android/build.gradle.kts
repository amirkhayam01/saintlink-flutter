allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

/*
 * Release builds run Android's "lint vital" pass on every plugin module. The
 * Stripe plugin's push-provisioning module declares play-services-tapandpay,
 * which Google publishes only to approved partners, so the pass fails trying
 * to fetch it even though we never touch tap-and-pay. Lint on our own :app
 * module still runs; only the plugins' vital pass is skipped.
 */
subprojects {
    if (name != "app") {
        tasks.configureEach {
            if (name.startsWith("lintVital")) {
                enabled = false
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
