
# This version of the code works. For the original version of the code check stack overflow.
# A few takeaways from this:
# 1. Tidy evaluation techniques that work with dplyr functions (e.g. enquo and !!) don't work with other functions 
# 2. Passing arguments to functions to non-standard evaluation arguments seems like a real pain.
# 3. It would be useful to dive into the guts of a package that uses subset to see what R programmers 
# typically do.


condition <- expression(cyl >=6)
lm(mpg~hp+am, subset =eval(condition), data = mtcars)

fit <- function(cond) {
  lm(mpg~hp+am, subset =eval(cond), data = mtcars)
}

fit(condition)
