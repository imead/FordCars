## Testing different methods in DataFrames and CairoMakie.
## Would also like to try to output report structure using Quarto

## Loading Packages
using DataFrames
using CSV

## Test making simple static DataFrame with tabular data from two vectors.
catnames = ["Lupin", "Big Kitty", "Hunter"]
badcatindex = [1, 3, 5]
df = DataFrame(; CatName=catnames, BadCatIndex=badcatindex)

## If outside of a function, will start cluttering workspace with variables
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
# this also works IF loadford function is replaced with df
filter(:model => ==("Focus"), loadford())  
filter(:model => !=("Focus"), loadford())

# THIS WORKS. indexing with broadcasting works perfectly.
# this does not work as function, only returns one row
df = loadford()
df[df.model .== ("Focus"), :]
loadford()[loadford().model .== ("Focus"), :]  

###### SUBSETTING ######
# helps with missing values, works on complete columns
subset(df, :model => ByRow(model -> model == "Focus"))

# argument for subset that helps with missing values
subset(df, :model => ByRow(model -> model == "Focus"); skipmissing=true)


####### Select #######
# can be used to remove column and more
# select two columns
select(loadford(), :model, :fuelType)
# remove column keeping all others
select(loadford(), Not(:fuelType))
# mix and match to move columns around
select(loadford(), :engineSize, Not(:engineSize))
# move mileage to second location
select(loadford(), 1, :mileage, :)

# rename columns
select(loadford(), :tax => "taxDollars", :)


###### using CategoricalArrays ######
using StatsBase
# This returns a dict with all the categories for that column
# Electric, Hybrid, Diesel, Petrol, Other
countmap(df.fuelType)


using CategoricalArrays
# practice ordering fuelType by arbitrary ecofriendly-ness
function categoryFuelType(df)
    levels = ["Electric", "Hybrid", "Petrol", "Diesel", "Other"]
    fuelType = categorical(df[!, :fuelType]; levels, ordered=true)
    df[!, :fuelType] = fuelType
    df
end

df = categoryFuelType(loadford())
sort(df, :fuelType)


###### JOINS ######
# current dataset not great for joins so will practice with book dataframes
function grades_2020()
    name = ["Sally", "Bob", "Alice", "Hank"]
    grade_2020 = [1, 5, 8.5, 4]
    DataFrame(; name, grade_2020)
end
grades_2020()

function grades_2021()
    name = ["Bob 2", "Sally", "Hank"]
    grade_2021 = [9.5, 9.5, 6.0]
    DataFrame(; name, grade_2021)
end
grades_2021()

# inner join
innerjoin(grades_2020(), grades_2021(); on=:name)

# outer join, will give missing type to those without values
outerjoin(grades_2020(), grades_2021(); on=:name)

# cartesian crossjoin
crossjoin(grades_2020(), grades_2021(); makeunique=true)

# also are normal leftjoin and rightjoin

#semijoin returns the elements from the left df that are in both dfs
semijoin(grades_2020(), grades_2021(); on=:name)

# antijoin returns electments from the left df that are not in the right df
antijoin(grades_2020(), grades_2021(); on=:name)

################################################################################
#################### VARIABLE TRANSFORMATIONS ####################
################################################################################

# add +1 to the numeric variable engineSize
addEngine(engine) = engine .+ 1
transform(loadford(), :engineSize => addEngine)
# replace old column with new calculated column
transform(loadford(), :engineSize => addEngine; renamecols=false)
# use select formatting, but dataframes option is more efficient
select(loadford(), :, :engineSize => addEngine => :engineSize)

#################### MULTIPLE TRANSFORMATIONS ####################

# create new column via logic from two existing and filter for true
pass(A, B) = [12000 < a && 100 < b for (a, b) in zip(A, B)]
df = transform(loadford(), [:price, :tax] => pass; renamecols=false)
passed = subset(df, :price_tax; skipmissing=true)