module.exports = {
  extends: [
    '@commitlint/config-conventional',
  ],
  rules: {
    'type-enum': [2, 'always', [
      'upd', 'feat', 'fix', 'refactor', 'docs', 'chore', 'style', 'revert',
    ]],
    'type-case': [0],
    'type-empty': [0],
    'scope-empty': [0],
    'scope-case': [0],
    'subject-full-stop': [0, 'never'],
    'subject-case': [0, 'never'],
    'header-max-length': [0, 'always', 72],
    'world-rule': [2, 'always'],
  },
  plugins: [
    {
      rules: {
        'world-rule': ({ subject }) => {
          const reg = /^([a-zA-Z ]+)$/;
          return [
            reg.test(subject),
            'Your subject should message English',
          ];
        },
      },
    },
  ],
};
