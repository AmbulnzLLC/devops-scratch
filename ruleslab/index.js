function Box(x) {
  rules = [];

  return {
    map:  f => Box(f(x)),
    fold: f => f ? f(x) : x,
    rules: rules,
    validate: () => rules.reduce((acc, f) => acc && f(x), true) 
  }
}

function Rule(b, p) {
  b.rules.push(p);
}

let str = Box("My string");
Rule(str, (s) => s === "My string");
Rule(str, (s) => s.length > 1);
console.log(str.validate());
