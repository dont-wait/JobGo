import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile

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

subprojects {
    tasks.withType<KotlinJvmCompile>().configureEach {
        // Some Flutter plugins still compile Java with 1.8/11 while Kotlin defaults to a newer target.
        // Align Kotlin bytecode target with the paired Java compile task for each variant.
        val javaTaskName = name.replace("Kotlin", "JavaWithJavac")
        val pairedJavaTask = project.tasks.findByName(javaTaskName)
        if (pairedJavaTask is org.gradle.api.tasks.compile.JavaCompile) {
            compilerOptions {
                jvmTarget.set(JvmTarget.fromTarget(pairedJavaTask.targetCompatibility))
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
