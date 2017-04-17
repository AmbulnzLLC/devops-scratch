function Box(x) {
  return {
    map:  f => Box(f(x)),
    fold: f => f(x),
    rules: [],
    validate: () => rules.reduce((acc, f) => acc && f(x), true) 
  }
}

function Rule(b, p) {
  b.rules.push(p);
}

let str = Box("My string");
Rule(str, (s) => s === "My string");
console.log(str.validate());
