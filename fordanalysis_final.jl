# after learning more of the DataFrames syntax and Julia syntax would
# like to actually dig into this dataset and create something with it

## Loading Packages
using DataFrames
using CSV
using StatsBase

## store import df in function for ease of reloading
function loadford()
    path = "data/ford.csv"
    CSV.read(path, DataFrame)
end

loadford()

## current working df
forddf = loadford()
forddf

## look at all the different model cars represented in the data
d1 = countmap(forddf.model)
d1
## look at the different fuel types represented
countmap(forddf.fuelType)

## examine years represented - most data from 2015-2019, ending in 2020
d1 = countmap(forddf.year)

## one car in 2060 - Fiesta which is probably data entry error
forddf[forddf.year .== 2060, :]

## some outlier years or errors need to be removed, want to subset from 2011-2020
forddf1 = filter(:year => year -> year >= 2011 && year <= 2020, forddf)
countmap(forddf1.year)

forddf2 = filter(:fuelType => fuelType -> fuelType != "Electric" && fuelType != "Other", forddf1)
countmap(forddf2.fuelType)