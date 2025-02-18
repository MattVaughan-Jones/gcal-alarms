## Get a fresh project

When you're ready, run:

```bash
npm run reset-project
```

This command will move the starter code to the **app-example** directory and create a blank **app** directory where you can start developing.

## When you add or update a dependency with native code

Run the following to generate the native project directories.

```bash
npx expo prebuild --clean
```

Then re-build the app.

```bash
npm run start:android
```
