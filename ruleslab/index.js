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

function Testable(x) {
  rules = [];

  return {
    fold: f => f ? f(x) : x,
    rule: (p) => rules.push(p),
    rules: rules,
    validate: () => rules.reduce((acc, f) => acc && f(x), true) 
  }
}

let str = Testable("My string");
str.rule(s => s === "My string");
str.rule(s => s.length > 1);
console.log(str.validate());

let int = Testable(13);
int.rule(i => i > 10);
int.rule(i => 1 % 2 === 0);
console.log(int.validate());

