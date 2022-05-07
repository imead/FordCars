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


## testing filter function in DataFrames - simple one line function
## simple bool function to look for string
boomFiesta(model::String) = model == "Fiesta"
boomFiesta("Fiesta") 
boomFiesta("MachE")

# filter for rows only with Fiesta
# the code in the book wasn't working, I think because of the different
# structure of my DataFrame. Below is the code I've found on Discourse
# but it only returns one row...
filter(x -> x[String("model")] == "Focus",loadford())

# these also only return one row. I am wondering if it is part of me
# storing a dataframe inside of a function...
filter(row -> row.model == "Focus", loadford())
loadford()[loadford().model .== "Focus", :]

df = loadford()
filter(x -> x[String("model")] == "Focus",df)
filter(row -> row.model == "Focus", df)

# THIS works...and it works with the loadford function as well
# occursin makes this a more flexible and less specific filter
# like a contains. I would like a more specific filter option too
x = filter(y -> any(occursin.(["Focus"], y.model)),loadford())

# interestingly while the first one only returns a single row
# the second one returns the whole dataframe minus 1 including
# rows with Focus in it.
filter(:model => ==("Focus"), loadford())  # this also works IF loadford function is replaced with df
filter(:model => !=("Focus"), loadford())

# THIS WORKS. indexing with broadcasting works perfectly.
df = loadford()
df[df.model .== ("Focus"), :]
loadford()[loadford().model .== ("Focus"), :]  # this does not work as functio, only returns one row


