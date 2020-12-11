package com.example.services

import com.example.Gingerbread
import com.example.Ingredient
import com.example.clients.FuelClient
import com.example.clients.RestTemplateClient
import com.example.requiredIngredients
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.supervisorScope
import org.springframework.stereotype.Service
import org.springframework.web.client.ResourceAccessException

@Service
class FoodMakerFuelService(fuelClient: FuelClient) : AbstractSuspendHandler(fuelClient)

@Service
class FoodMakerRestTemplateService(restTemplateClient: RestTemplateClient) : AbstractSuspendHandler(restTemplateClient)

@Service
class FoodMakerSuspendingService(restTemplateClient: RestTemplateClient) : AbstractSuspendHandler(restTemplateClient) {
    override suspend fun prepareGingerbread(existingIngredients: Set<Ingredient>): Gingerbread? {
        return supervisorScope { //prevents from exception propagation
            val missingIngredientsBought = execBlocking { buyMissingIngredients(requiredIngredients, existingIngredients) }
            if (!missingIngredientsBought) {
                throw RuntimeException("cannot get missing ingredients")
            }

            val oven = heatOven()
            val heat = async { heatButterWithHoney() }
            val dough = async { prepareDough() }
            val mixedDoughWithButter = execBlocking { mixDoughWithButter(heat.await(), dough.await()) }

            val tray = async { prepareCakeTray() }
            val baked = execBlocking { bake(oven, mixedDoughWithButter, tray.await()) }
            val icing = execBlocking { prepareIcing() }

            Gingerbread(baked, icing)
        }
    }

    private suspend fun CoroutineScope.execBlocking(block: suspend CoroutineScope.() -> Boolean) =
        try {
            async(block = block).await()
        } catch (ex: ResourceAccessException) {
            false
        }


}

