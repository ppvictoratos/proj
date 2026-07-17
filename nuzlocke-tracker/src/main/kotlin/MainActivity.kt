package com.shneakypete.nuzlocke

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            NuzlockeApp()
        }
    }
}

@Composable
fun NuzlockeApp() {
    MaterialTheme {
        Surface {
            // TODO: Main navigation and UI
        }
    }
}
