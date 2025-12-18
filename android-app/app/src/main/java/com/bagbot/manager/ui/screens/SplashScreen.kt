package com.bagbot.manager.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bagbot.manager.ui.theme.*
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onFinished: () -> Unit) {
    var isLoading by remember { mutableStateOf(true) }
    val infiniteTransition = rememberInfiniteTransition(label = "splash")
    
    val scale by infiniteTransition.animateFloat(
        initialValue = 0.8f,
        targetValue = 1.2f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = EaseInOutQuad),
            repeatMode = RepeatMode.Reverse
        ),
        label = "scale"
    )
    
    LaunchedEffect(Unit) {
        delay(2000)
        isLoading = false
        onFinished()
    }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(BagDarkPurple, BagPurple, BagPink)
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "BAG",
                fontSize = 72.sp,
                fontWeight = FontWeight.Bold,
                color = BagWhite,
                modifier = Modifier.scale(scale)
            )
            
            Spacer(modifier = Modifier.height(32.dp))
            
            Text(
                text = "Bot Manager",
                fontSize = 24.sp,
                fontWeight = FontWeight.Light,
                color = BagLightPurple
            )
            
            Spacer(modifier = Modifier.height(48.dp))
            
            if (isLoading) {
                CircularProgressIndicator(
                    color = BagWhite,
                    strokeWidth = 3.dp
                )
            }
        }
    }
}
