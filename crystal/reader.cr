require "./types"

class Reader
  def initialize(@tokens)
    @pos = 0
  end

  def current_token
    @tokens[@pos] rescue nil
  end

  def peek
    t = current_token

    if t && t[0] == ';'
      @pos += 1
      peek
    else
      t
    end
  end

  def next
    peek
  ensure
    @pos += 1
  end
end

def tokenize(str)
  regex = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
  str.scan(regex).map{|m| m[1]}.reject(&.empty?)
end

def read_str(str)
  r = Reader.new(tokenize(str))
  begin
    read_form r
  ensure
    unless r.peek.nil?
      raise "expected EOF, got #{r.peek.to_s}"
    end
  end
end

def parse_error(msg)
  raise Mal::ParseException.new msg
end

def read_sequence(reader, init, open, close)
  token = reader.next
  parse_error "expected '#{open}', got EOF" unless token
  parse_error "expected '#{open}', got #{token}" unless  token[0] == open

  loop do
    token = reader.peek
    parse_error "expected '#{close}', got EOF" unless token
    break if token[0] == close

    init << read_form reader
    reader.peek
  end

  reader.next
  init
end

def read_list(reader)
  read_sequence(reader, Mal::List.new, '(', ')')
end

def read_vector(reader)
  read_sequence(reader, Mal::Vector.new, '[', ']')
end

def read_atom(reader)
  token = reader.next
  parse_error "expected Atom but got EOF" unless token

  case
  when token =~ /^-?\d+$/ then token.to_i
  when token == "true"    then true
  when token == "false"   then false
  when token == "nil"     then nil
  when token[0] == '"'    then token[1..-2].gsub(/\\"/, "\"")
  else                         Mal::Symbol.new token
  end
end

def list_of(symname, reader)
  reader.next
  Mal::List.new << Mal::Symbol.new(symname) << read_form(reader)
end

def read_form(reader) : Mal::Type
  token = reader.peek

  parse_error "unexpected EOF" unless token
  parse_error "unexpected comment" if token[0] == ';'

  case token
  when "("  then read_list reader
  when ")"  then parse_error "unexpected ')'"
  when "["  then read_vector reader
  when "]"  then parse_error "unexpected ']'"
  when "'"  then list_of("quote", reader)
  when "`"  then list_of("quasiquote", reader)
  when "~"  then list_of("unquote", reader)
  when "~@" then list_of("splice-unquote", reader)
  when "^"  then list_of("with-meta", reader)
  when "@"  then list_of("deref", reader)
  else read_atom reader
  end
end

require "./printer"
puts pr_str(read_str("[+ 1 2] ; bar"))
