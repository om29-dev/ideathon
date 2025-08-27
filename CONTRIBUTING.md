# Contributing to AI Finance Assistant

Thank you for your interest in contributing to the AI Finance Assistant! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/ideathon.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Follow the setup instructions in [README.md](README.md)

## 🏗️ Development Workflow

### Backend Development
- Located in `/backend/`
- Uses FastAPI with Python 3.8+
- Follow PEP 8 style guidelines
- Add type hints to all functions
- Test your changes with `python main.py`

### Frontend Development
- Located in `/frontend/`
- Uses Flutter 3.8.1+
- Follow Flutter/Dart style guidelines
- Test on multiple platforms when possible
- Use `flutter analyze` before committing

### Code Style

#### Python (Backend)
```python
# Good
def generate_tip(category: str) -> dict:
    """Generate a financial tip for the given category."""
    return {"tip": "Save money daily!"}

# Bad
def generate_tip(category):
    return {"tip": "Save money daily!"}
```

#### Dart (Frontend)
```dart
// Good
class FinanceService {
  static Future<Map<String, dynamic>> getTips() async {
    // Implementation
  }
}

// Bad
class financeService {
  getTips() {
    // Implementation
  }
}
```

## 📝 Commit Messages

Use conventional commits:
- `feat: add new expense tracking feature`
- `fix: resolve notification permission issue`
- `docs: update setup instructions`
- `style: format code according to guidelines`
- `refactor: improve API response structure`

## 🧪 Testing

### Backend Testing
```bash
cd backend
python -m pytest tests/
```

### Frontend Testing
```bash
cd frontend
flutter test
```

## 🐛 Bug Reports

When filing a bug report, please include:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Platform/OS information
- Flutter/Python version

## 💡 Feature Requests

- Check existing issues first
- Provide clear use case
- Explain expected behavior
- Consider implementation complexity

## 📋 Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all tests pass
4. Update CHANGELOG.md
5. Request review from maintainers

## 🔧 Development Environment

### Required Tools
- Python 3.8+
- Flutter 3.8.1+
- Git
- VS Code (recommended)

### Recommended VS Code Extensions
- Python
- Flutter
- Dart
- GitLens
- Better Comments

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Google Gemini AI](https://ai.google.dev/)

## 🤝 Community

- Be respectful and inclusive
- Help others learn and grow
- Share knowledge and best practices
- Follow our Code of Conduct

## 📄 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Happy Coding! 🚀**
