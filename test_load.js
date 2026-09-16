try {
  require('./server');
  console.log('Server loaded OK');
} catch(e) {
  console.log('ERROR:', e.message);
  console.log(e.stack);
}