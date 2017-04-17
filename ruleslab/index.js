function Testable(x) {
  rules = [];

  return {
    unbox: f => f ? f(x) : x,
    rule: (p) => rules.push(p),
    rules: rules,
    test: () => rules.reduce((acc, f) => acc && f(x), true) 
  }
}

const evenNumberRule = i => i % 2 === 0;

let str = Testable("My string");
str.rule(s => s === "My string");
str.rule(s => s.length > 1);
console.log(str.test());

let int = Testable(13);
int.rule(i => i > 10);
int.rule(evenNumberRule);
console.log(int.test());
