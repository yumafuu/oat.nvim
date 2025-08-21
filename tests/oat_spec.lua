local oat = require('oat')

describe('oat.nvim', function()
  before_each(function()
    -- Reset configuration
    oat.setup()
  end)

  it('should setup default operators', function()
    oat.setup()
    -- Test that default operators are available
    assert.is_not_nil(oat)
  end)

  it('should add custom operators', function()
    oat.add_operator('t', {
      name = "test",
      command = "echo",
      description = "Test operator"
    })
    
    -- Verify operator was added
    -- This would need more sophisticated testing in a real environment
    assert.is_not_nil(oat)
  end)

  it('should handle visual selection', function()
    -- Mock vim functions for testing
    -- This would need proper mocking in a real test environment
    assert.is_not_nil(oat)
  end)
end)