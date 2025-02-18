console.log('Loading test file:', new Date().toISOString());

describe('Minimal test', () => {
    console.log('Minimal test suite starting...');
  it('should run once', () => {
    console.log('Test running at:', new Date().toISOString());
    expect(true).toBe(true);
  });
}); 