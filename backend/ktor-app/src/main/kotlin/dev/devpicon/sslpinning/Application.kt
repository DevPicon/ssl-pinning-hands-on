package dev.devpicon.sslpinning

import io.ktor.http.HttpStatusCode
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.engine.connector
import io.ktor.server.engine.embeddedServer
import io.ktor.server.engine.sslConnector
import io.ktor.server.netty.Netty
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation
import io.ktor.server.response.respond
import io.ktor.server.routing.get
import io.ktor.server.routing.routing
import java.io.FileInputStream
import java.security.KeyStore

fun main() {
    val keyStorePath = System.getenv("KEYSTORE_PATH") ?: "backend/certs/keystore.p12"
    val keyStorePassword = System.getenv("KEYSTORE_PASSWORD") ?: "password"
    val keyAlias = System.getenv("KEY_ALIAS") ?: "ktor"

    val keyStore = KeyStore.getInstance("PKCS12").apply {
        FileInputStream(keyStorePath).use { input ->
            load(input, keyStorePassword.toCharArray())
        }
    }

    embeddedServer(
        factory = Netty,
        configure = {
            connector {
                host = "0.0.0.0"
                port = 8080
            }

            sslConnector(
                keyStore = keyStore,
                keyAlias = keyAlias,
                keyStorePassword = { keyStorePassword.toCharArray() },
                privateKeyPassword = { keyStorePassword.toCharArray() }
            ) {
                host = "0.0.0.0"
                port = 8443
            }
        },
        module = Application::module
    ).start(wait = true)
}

fun Application.module() {
    install(ContentNegotiation) {
        json()
    }

    routing {
        get("/") {
            call.respond(
                HttpStatusCode.OK,
                mapOf("message" to "SSL Pinning Hands-on Backend")
            )
        }

        get("/health") {
            call.respond(
                HttpStatusCode.OK,
                mapOf("status" to "ok")
            )
        }

        get("/secure-data") {
            call.respond(
                HttpStatusCode.OK,
                mapOf("data" to "This response comes from a TLS-enabled Ktor backend")
            )
        }
    }
}