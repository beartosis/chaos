# Testing Patterns Standards

## Test Structure

Use Arrange-Act-Assert (AAA):

```python
def test_user_can_place_order():
    # Arrange
    user = create_user(balance=100)
    product = create_product(price=50)

    # Act
    order = place_order(user, product)

    # Assert
    assert order.status == "confirmed"
    assert user.balance == 50
```

## Naming

Name tests to describe the scenario:

```python
# Good
def test_order_fails_when_insufficient_balance():
def test_email_sent_after_successful_signup():

# Bad
def test_order():
def test_signup_email():
```

## Assertions

- One logical assertion per test
- Use descriptive assertion messages
- Assert on behavior, not implementation

## Test Data

- Use factories or fixtures for test data
- Keep test data minimal but realistic
- Avoid sharing mutable state between tests

## Mocking

- Mock external services and I/O
- Don't mock the code under test
- Prefer fakes over mocks when possible
- Verify mock interactions sparingly
