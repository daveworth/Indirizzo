module Indirizzo
  # Defines the matching of parsed address tokens.
  Match = {
    # FIXME: shouldn't have to anchor :number and :zip at start/end
    :number   => /^(\d+\W|[a-z]+)?(\d+)([a-z]?)\b/io,
    :street   => /(?:\b(?:\d+\w*|[a-z'-]+)\s*)+/io,
    :city     => /(?:\b[a-z][a-z'-]+\s*)+/io,
    :state    => State.regexp,
    :zip      => /\b(\d{5})(?:-(\d{4}))?\b/o,
    :at       => /\s(at|@|and|&)\s/io,
    :po_box => /\b[P|p]*(OST|ost)*\.*\s*[O|o|0]*(ffice|FFICE)*\.*\s*[B|b][O|o|0][X|x]\b/
  }
end
