//
//  DemoMeal.swift
//  Ratatouille
//
//  Created by Candidate no.2017 on 26/11/2023.
//

import SwiftUI

struct DemoMeal {
    @State public var meal: MealModel = {
            var meal = MealModel(
                id: "52908",
                name: "Ratatouille",
                image: "https://www.themealdb.com/images/media/meals/wrpwuu1511786491.jpg",
                instructions: "Cut the aubergines in half lengthways. Place them on the board, cut side down, slice in half lengthways again and then across into 1.5cm chunks.\r\n\nCut off the courgettes ends, then across into 1.5cm slices. Peel the peppers from stalk to bottom. Hold upright, cut around the stalk, then cut into 3 pieces. Cut away any membrane, then chop into bite-size chunks.\r\n\nScore a small cross on the base of each tomato, then put them into a heatproof bowl. Pour boiling water over the tomatoes, leave for 20 secs, then remove. Pour the water away, replace the tomatoes and cover with cold water. Leave to cool, then peel the skin away. Quarter the tomatoes, scrape away the seeds with a spoon, then roughly chop the flesh.\r\n\nSet a sauté pan over medium heat and when hot, pour in 2 tbsp olive oil. Brown the aubergines for 5 mins on each side until the pieces are soft. Set them aside and fry the courgettes in another tbsp oil for 5 mins, until golden on both sides. Repeat with the peppers. Don’t overcook the vegetables at this stage, as they have some more cooking left in the next step.\r\n\nTear up the basil leaves and set aside. Cook the onion in the pan for 5 mins. Add the garlic and fry for a further min. Stir in the vinegar and sugar, then tip in the tomatoes and half the basil. Return the vegetables to the pan with some salt and pepper and cook for 5 mins. Serve with basil.",
                area: AreaModel(name: "French")!,
                category: CategoryModel(id: "12", name: "Vegetarian", image: "https://www.themealdb.com/images/category/vegetarian.png", information: "Vegetarianism is the practice of abstaining from the consumption of meat (red meat, poultry, seafood, and the flesh of any other animal), and may also include abstention from by-products of animal slaughter.\r\n\r\nVegetarianism may be adopted for various reasons. Many people object to eating meat out of respect for sentient life. Such ethical motivations have been codified under various religious beliefs, as well as animal rights advocacy. Other motivations for vegetarianism are health-related, political, environmental, cultural, aesthetic, economic, or personal preference. There are variations of the diet as well: an ovo-lacto vegetarian diet includes both eggs and dairy products, an ovo-vegetarian diet includes eggs but not dairy products, and a lacto-vegetarian diet includes dairy products but not eggs. A vegan diet excludes all animal products, including eggs and dairy. Some vegans also avoid other animal products such as beeswax, leather or silk clothing, and goose-fat shoe polish.")!,
                ingredients: [
                    IngredientModel(id: "11", name: "Aubergine, 2 large", information: "Eggplant (US, Australia), aubergine (UK), or brinjal (South Asia and South Africa) is a plant species in the nightshade family Solanaceae. Solanum melongena is grown worldwide for its edible fruit. Most commonly purple, the spongy, absorbent fruit is used in various cuisines. Although often considered a vegetable, it is a berry by botanical definition. As a member of the genus Solanum, it is related to tomato and potato. Like the tomato, its skin and seeds can be eaten, but, like the potato, it is usually eaten cooked. Eggplant is nutritionally low in macronutrient and micronutrient content, but the capability of the fruit to absorb oils and flavors into its flesh through cooking expands its use in the culinary arts. It was originally domesticated from the wild nightshade species thorn or bitter apple, S. incanum, probably with two independent domestications: one in South Asia, and one in East Asia.", image: nil)!,
                    IngredientModel(id: "426", name: "Courgettes, 4", information: nil, image: nil)!,
                    IngredientModel(id: "424", name: "Yellow Pepper, 2", information: nil, image: nil)!,
                    IngredientModel(id: "365", name: "Tomato, 4 large", information: nil, image: nil)!,
                    IngredientModel(id: "224", name: "Olive Oil, 5 tbs", information: nil, image: nil)!,
                    IngredientModel(id: "17", name: "Basil, Bunch", information: "Basil, also called great basil, is a culinary herb of the family Lamiaceae (mints).\r\n\r\nBasil is native to tropical regions from central Africa to Southeast Asia. It is a tender plant, and is used in cuisines worldwide. Depending on the species and cultivar, the leaves may taste somewhat like anise, with a strong, pungent, often sweet smell.", image: nil)!,
                    IngredientModel(id: "364", name: "Onion, 1 medium", information: nil, image: nil)!,
                    IngredientModel(id: "150", name: "Garlic Clove, 3 finely chopped", information: nil, image: nil)!,
                    IngredientModel(id: "394", name: "Red Wine Vinegar, 1 tsp", information: nil, image: nil)!,
                    IngredientModel(id: "304", name: "Sugar, 1 tsp", information: nil, image: nil)!
                ],
                isFavorite: false
            )

            // Additional setup or modifications if needed

        return meal!
        }()
}
