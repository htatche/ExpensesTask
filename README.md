# ExpensesTask

## Install

```
git clone https://github.com/htatche/ExpensesTask
cd ExpensesTask
cd backend && bundle install && bin/rake db:migrate && cd ../frontend && npm install
```

## Run the back-end

```
cd backend
bin/rails s
```

## Run the front-end

```
cd frontend
yarn start
```

## back-end specs

```
cd backend
bin/rspec spec
