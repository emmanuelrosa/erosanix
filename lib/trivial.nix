{ 
  # Applies 1st function in the list (xs) to the argument (arg),
  # then applies the 2nd function in the list, and so on.
  composeAndApply = xs: arg: builtins.foldl' (x: f: f x) arg xs;
}
