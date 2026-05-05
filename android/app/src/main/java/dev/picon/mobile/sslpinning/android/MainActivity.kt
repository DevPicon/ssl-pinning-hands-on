package dev.picon.mobile.sslpinning.android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {

    private val viewModel: MainViewModel by viewModels {
        MainViewModelFactory(
            sslPin = BuildConfig.SSL_PIN
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            val uiState = viewModel.uiState

            Column(modifier = Modifier.padding(24.dp)) {
                Button(
                    enabled = !uiState.isLoading,
                    onClick = { viewModel.callBackend() }
                ) {
                    Text("Call HTTPS Backend")
                }

                Text(
                    text = uiState.message,
                    modifier = Modifier.padding(top = 16.dp)
                )
            }
        }
    }
}