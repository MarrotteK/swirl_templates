########################################################
# Written by Kyle A. Marrotte
# With tons of assistance by Dr. Garret M. Dancik
# Released under a Creative Commons Attribution-ShareAlike 4.0 
# International license, because education should always be free.
########################################################
library(yaml)     #
library(swirl)    #Makes absolutely sure all the required libraries are loaded
library(swirlify) #

file.template = "./lesson.yaml"

tokens.replace <- function(x,y){ #Takes tokens.create and applies it to df
  for (i in 1:length(y)){
    x = lapply(x, function(x) sub(paste0("<",y[[i]][1],">"), y[[i]][2], x)) #goes through and overwrites the tokens with their output
    }  #lapply required to preserve data.frame
  return(x)
}

tokens.create <- function(.token.str) { #creates tokens based on code from 'token' class
  eval(parse(text = .token.str))   #pulls the code out of the character string and executes it using magic
  a = ls.str()       # creates a vector of tokens in the function environment
  x = list()                      #creates blank list
  for (i in 1:length(a)){
    x[[i]] = c(a[i], get(a[i])) #fills list x with tokens and executed code
  }
  return(x)
}

newrow <- function(element){
  temp <- data.frame(Class=NA, Token=NA, Output=NA, CorrectAnswer=NA, #added the new row 'Token'
                     AnswerChoices=NA, AnswerTests=NA,
                     Hint=NA, Figure=NA, FigureType=NA,
                     VideoLink=NA, Script=NA)
  
  for(nm in names(element)){
    # Only replace NA with value if value is not NULL, i.e. instructor
    # provided a nonempty value
    if(!is.null(element[[nm]])) {
      temp[,nm] <- element[[nm]]
    }
  }
  return(temp)
}

parse_content.yaml <- function(file, e){
  raw_yaml <- yaml.load_file(file)
  temp <- lapply(raw_yaml[-1], newrow) #combines raw_yaml with the newrow function
  df <- NULL
  for(row in temp){
    df <- rbind(df, row) #combines df and df.template[1,]
  }
  
  #save(df, file = "yaml.RData")  #Optional, if you want an output file
  meta <- raw_yaml[[1]]
  
  return(df)
}

row = df.template[1,]

token.generate <- function(row){
  if(!is.na(row$Token)){                #If there's anything in the 'Token' row,
    tokens <- tokens.create(row$Token)  #create the tokens,
    row <- tokens.replace(row, tokens)  #then replace the tokens
  }
  return(row)
}

df.template = parse_content.yaml(file.template) #shortcut to test everything more easily

row.orig = df.template[2,] #takes the second row from all the above functions
new.row = token.generate(row.orig) #runs token generate on the above


assignInNamespace("parse_content.yaml", parse_content.yaml, "swirl") #overwrites the default parse_content.yaml in namespace

