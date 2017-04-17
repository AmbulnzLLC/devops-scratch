function Testable(x) {
  rules = [];

  return {
    unbox: f => f ? f(x) : x,
    rule: (p) => rules.push(p),
    shouldEqual: (v) => rules.push(x => x === v),
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

let twelve = Testable(12);
twelve.rule(evenNumberRule);
twelve.shouldEqual(12);
console.log(twelve.test());
