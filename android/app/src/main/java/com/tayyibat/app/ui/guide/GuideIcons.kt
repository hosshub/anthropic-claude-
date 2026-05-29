package com.tayyibat.app.ui.guide

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BakeryDining
import androidx.compose.material.icons.filled.Cake
import androidx.compose.material.icons.filled.Egg
import androidx.compose.material.icons.filled.Grain
import androidx.compose.material.icons.filled.LocalCafe
import androidx.compose.material.icons.filled.LocalDrink
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.RiceBowl
import androidx.compose.material.icons.filled.SetMeal
import androidx.compose.material.icons.filled.Spa
import androidx.compose.material.icons.filled.WaterDrop
import androidx.compose.ui.graphics.vector.ImageVector

/** خرائط معرّف الفئة إلى أيقونة Material مناسبة. */
fun categoryIcon(id: String): ImageVector = when (id) {
    "starches" -> Icons.Filled.RiceBowl
    "fats" -> Icons.Filled.WaterDrop
    "cheese" -> Icons.Filled.BakeryDining
    "vegetables" -> Icons.Filled.Spa
    "meats" -> Icons.Filled.Restaurant
    "poultry" -> Icons.Filled.Egg
    "fruits" -> Icons.Filled.Cake
    "drinks" -> Icons.Filled.LocalCafe
    "sweets" -> Icons.Filled.Cake
    "nuts" -> Icons.Filled.Grain
    "pickles" -> Icons.Filled.Spa
    "processed_grains" -> Icons.Filled.BakeryDining
    "dairy" -> Icons.Filled.LocalDrink
    "eggs" -> Icons.Filled.Egg
    "legumes" -> Icons.Filled.Grain
    "seafood" -> Icons.Filled.SetMeal
    else -> Icons.Filled.Restaurant
}
