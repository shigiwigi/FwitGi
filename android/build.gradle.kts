allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Move the buildDir configuration here if it was previously at the top-level
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Define kotlin_version directly within the buildscript block for proper scoping
buildscript {
    val kotlin_version = "1.7.10" // Defined here to be accessible within this block

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version") // Now kotlin_version is in scope
        classpath("com.google.gms:google-services:4.4.1")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}