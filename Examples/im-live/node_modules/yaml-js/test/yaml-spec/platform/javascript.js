module.exports = {
  floats: [
    {
      yaml:   ".inf",
      result: Infinity
    },
    {
      yaml:   "-.inf",
      result: -Infinity
    },
    {
      yaml:   ".NaN",
      result: NaN
    }
  ],
  timestamps: [
    {
      yaml:   "2001-12-15T02:59:43.1Z",
      result: new Date(Date.UTC(2001, 11, 15, 2, 59, 43, 100))
    },
    {
      yaml:   "2001-12-14t21:59:43.10-05:00",
      result: new Date(Date.UTC(2001, 11, 15, 2, 59, 43, 100))
    },
    {
      yaml:   "2001-12-14 21:59:43.10 -5",
      result: new Date(Date.UTC(2001, 11, 15, 2, 59, 43, 100))
    },
    {
      yaml:   "2001-12-15 2:59:43.10",
      result: new Date(Date.UTC(2001, 11, 15, 2, 59, 43, 100))
    },
    {
      yaml:   "2002-12-14",
      result: new Date(Date.UTC(2002, 11, 14, 0, 0, 0, 0))
    }
  ]
};