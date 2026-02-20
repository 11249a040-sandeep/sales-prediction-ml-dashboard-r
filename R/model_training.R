library(randomForest)

# Load dataset
data <- read.csv("data/sales.csv")

# Train Random Forest model
model <- randomForest(total.exports ~ beef + pork + poultry,
                      data = data)

# Save trained model
saveRDS(model, "output/model.rds")

cat("Model training complete!")