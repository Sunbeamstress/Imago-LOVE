function legal_character(c)
    return string.byte(c) >= 32 and string.byte(c) <= 126
end