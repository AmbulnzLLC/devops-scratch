function Box(x) {
  return {
    map:  f => Box(f(x)),
    fold: f => f(x)
  }
}

let str = Box("My string");

str.rule = s => s = "My string";

console.log(str.fold(x => rule(x)));
