plugins {
    kotlin("jvm") version "2.2.20"
    application
    id("io.ktor.plugin") version "3.4.2"
}

group = "dev.devpicon"
version = "0.1.0"

application {
    mainClass.set("dev.devpicon.sslpinning.ApplicationKt")
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("io.ktor:ktor-server-core:3.4.2")
    implementation("io.ktor:ktor-server-netty:3.4.2")
    implementation("io.ktor:ktor-server-content-negotiation:3.4.2")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.4.2")

    implementation("ch.qos.logback:logback-classic:1.5.18")
}