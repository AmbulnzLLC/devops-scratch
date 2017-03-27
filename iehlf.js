let greeting = 'hello'
let greetingFactory = ((g) => () => `${g}, world.`)(greeting) 
console.log(greetingFactory)
