## Testing different methods in DataFrames and CairoMakie.
## Would also like to try to output report structure using Quarto

## Loading Packages
using DataFrames
using CSV

## Test making simple static DataFrame with tabular data from two vectors.
catnames = ["Lupin", "Big Kitty", "Hunter"]
badcatindex = [1, 3, 5]
df = DataFrame(; CatName=catnames, BadCatIndex=badcatindex)

## If produced outside of a function, will start cluttering workspace with functions
## Recall that ; triggers named tuple construction.
function badcats()
    catnames = ["Lupin", "Big Kitty", "Hunter"]
    badcatindex = [1, 3, 5]
    DataFrame(; catnames, badcatindex)
end
badcats()


## Load CSV file from Kaggle for Ford Cars Analysis
## Store path in variable, use read function specifying DataFrame
path = "ford.csv"
df = CSV.read(path, DataFrame)


## Place into function to further manipulate.
function loadford()
    path = "ford.csv"
    CSV.read(path, DataFrame)
end

loadford()

## Fetch vector containing model name
function modelname()
    df = loadford()
    df.model
end 

## returns type pooledarrays.pooledvector
## discourse explanation says this is normal for CSV.jl.
## PooledArray is a simple dictionary that is more efficient 

modelname()

## Another method of indexing a column

function modelname2()
    df = loadford()
    df[!, :model]
end
modelname2()

## Index a row - row 4
function modelrow(i::Int)
    df = loadford()
    df[i,:]
end
modelrow(4)

## example of slicing to get just model names from the top 10
modelnames(df) = df[1:10, :model]
modelnames(loadford())


## testing filter function in DataFrames
