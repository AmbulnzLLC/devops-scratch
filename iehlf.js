let greeting = 'hello'

let greeter = (function(g) {
  return function() {
    console.log(g)
  }
})(greeting)

greeter()
