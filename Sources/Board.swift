//
//  Board.swift
//  Chess
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// A chess board.
public struct Board: Equatable {

    /// A chess board space.
    public struct Space: Equatable, CustomStringConvertible {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// The space's color.
        public var color: Color {
            return (file.index % 2 != rank.index % 2) ? .White : .Black
        }

        /// The space's name.
        public var name: String {
            return "\(file.character)\(rank.rawValue)"
        }

        /// A textual representation of `self`.
        public var description: String {
            return "Space(\"\(name)\" \(piece.map({ String($0) }) ?? "nil"))"
        }

        /// Create a chess board space.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.piece = piece
            self.file = file
            self.rank = rank
        }

        /// Clears the piece from the space and returns it.
        public mutating func clear() -> Piece? {
            let piece = self.piece
            self.piece = nil
            return piece
        }

    }

    /// The board's spaces.
    private var _spaces: [[Space]]

    /// The board's pieces.
    public var pieces: [Piece] {
        return _spaces.flatten().flatMap({ $0.piece })
    }

    /// The board's white pieces.
    public var whitePieces: [Piece] {
        return pieces.filter({ $0.color.isWhite })
    }

    /// The board's black pieces.
    public var blackPieces: [Piece] {
        return pieces.filter({ $0.color.isBlack })
    }

    /// Creates a chess board.
    ///
    /// - Parameter populate: If `true`, the board is populated. Default is `true`.
    public init(populate: Bool = true) {
        let range = 0...7
        self._spaces = range.reduce([]) { spaces, x in
            spaces + [
                range.reduce([]) {
                    $0 + [Space(file: File(column: x)!, rank: Rank(row: $1)!)]
                }
            ]
        }
        if populate {
            self.populate()
        }
    }

    /// Gets and sets a piece at the file and rank.
    public subscript(file: File, rank: Rank) -> Piece? {
        get {
            return spaceAt(file, rank).piece
        }
        set {
            _spaces[file.index][rank.index].piece = newValue
        }
    }

    /// Populates `self` with with all of the pieces at their proper locations.
    public mutating func populate() {
        self.clear()
        for x in 0...7 {
            _spaces[x][1].piece = .Pawn(.White)
            _spaces[x][6].piece = .Pawn(.Black)
        }
        for (y, color) in [(0, Color.White), (7, Color.Black)] {
            _spaces[0][y].piece = .Rook(color)
            _spaces[1][y].piece = .Knight(color)
            _spaces[2][y].piece = .Bishop(color)
            _spaces[3][y].piece = .Queen(color)
            _spaces[4][y].piece = .King(color)
            _spaces[5][y].piece = .Bishop(color)
            _spaces[6][y].piece = .Knight(color)
            _spaces[7][y].piece = .Rook(color)
        }
    }

    /// Clears all the pieces from `self`.
    public mutating func clear() {
        let range = 0...7
        for x in range {
            for y in range {
                _spaces[x][y].clear()
            }
        }
    }

    /// Returns the spaces at the file.
    @warn_unused_result
    public func spacesAtFile(file: File) -> [Space] {
        return _spaces[file.index]
    }

    /// Returns the spaces at the rank.
    @warn_unused_result
    public func spacesAtRank(rank: Rank) -> [Space] {
        return _spaces.map({ $0[rank.index] })
    }

    /// Returns the space at the file and rank.
    @warn_unused_result
    public func spaceAt(file: File, _ rank: Rank) -> Space {
        return _spaces[file.index][rank.index]
    }

}

/// Returns `true` if both boards are the same.
@warn_unused_result
public func == (lhs: Board, rhs: Board) -> Bool {
    for (ls, rs) in zip(lhs._spaces, rhs._spaces) {
        guard ls == rs else {
            return false
        }
    }
    return true
}

/// Returns `true` if both spaces are the same.
@warn_unused_result
public func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
    return lhs.piece == rhs.piece
        && lhs.file == rhs.file
        && lhs.rank == rhs.rank
}
