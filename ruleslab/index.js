function Box(x) {
  return {
    map:  f => Box(f(x)),
    fold: f => f(x)
  }
}

let str = Box("My string");
str.rule = () => str.fold(s => s) === "My string";
console.log(str.rule());
