# Frontend Accessibility Standards

## Core Requirements

- All interactive elements keyboard accessible
- Proper heading hierarchy (h1 → h2 → h3)
- Alt text for meaningful images
- Sufficient color contrast (4.5:1 minimum)

## ARIA Usage

Use ARIA when native HTML is insufficient:

```html
<!-- Good: Native HTML -->
<button>Submit</button>

<!-- Good: ARIA for custom widget -->
<div role="button" tabindex="0" aria-pressed="false">Toggle</div>

<!-- Bad: Redundant ARIA -->
<button role="button">Submit</button>
```

## Focus Management

- Visible focus indicators
- Logical tab order
- Focus trapping in modals
- Return focus after modal closes

## Forms

- Labels associated with inputs
- Error messages linked to fields
- Required fields indicated
- Form validation announcements

## Testing

- Test with keyboard navigation
- Test with screen reader
- Use accessibility linting tools
