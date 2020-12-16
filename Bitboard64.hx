package;


    class Bitboard64
    {
        public var lower:Int = 0;
        public var upper:Int = 0;	
        public var count:Int = 0;
        public var needCount:Bool = false;
        
        public function new(l:Int=0, u:Int=0) {
		lower = l;
		upper = u;
         }
        
        public function Clear()	: Void
        {
            lower = 0;
            upper = 0;		
            count = 0;
            needCount = false;
        }
        
        public function Copy( other:Bitboard64 ) : Void	
        {
            lower = other.lower;
            upper = other.upper;		
            count = other.count;
            needCount = other.needCount;
        }
        
	public function newCOPY():Bitboard64 {
		var newBB:Bitboard64 = new Bitboard64();
		newBB.Copy(this);
		return newBB;
	}

        public function Equals( other:Bitboard64 )	: Bool
        {
            if( lower == other.lower &&
                upper == other.upper )
            {
                return true;
            }
            return false;
        }
        
	    // for StockFish コンストラクタと逆
        public function Init( u:Int=0, l:Int=0 ) : Void
        {
            lower = l;
            upper = u;
            
            // var len:Int = theHex.length;
            // if( len <= 8 )
            // {
            //     lower = Std.parseInt( theHex );			
            // }
            // else
            // {
            //     lower = Std.parseInt( theHex.substring( len-8 ) );			
            //     upper = Std.parseInt( theHex.substring( 0, len-8 ) );
            // }
                    
            needCount = true;
        }
        
        public function SetInt( theInt:Int ) : Void
        {
            upper = 0;
            lower = theInt;
            needCount = true;
        }
        
        
        public function AND( other:Bitboard64 ) : Void
        {
            lower &= other.lower;
            upper &= other.upper;	
            needCount = true;	
        }
        
        public function newAND( other:Bitboard64 ) : Bitboard64
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.AND( other );
            return newBB;				
        }
            
        public function OR( other:Bitboard64 )	: Void
        {
            lower |= other.lower;
            upper |= other.upper;		
            needCount = true;	
        }
            
        public function newOR( other:Bitboard64 ) : Bitboard64
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.OR( other );
            return newBB;
        }
        
        public function XOR( other:Bitboard64 ) : Void	
        {
            lower ^= other.lower;
            upper ^= other.upper;
            needCount = true;	
        }
        
        public function newXOR( other:Bitboard64 ) : Bitboard64
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.XOR( other );
            return newBB;
        }
        
        public function NOT() : Void
        {
            lower = ~lower;
            upper = ~upper;
            count = 64 - count;		
        }
        
        public function newNOT() : Bitboard64
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.NOT();
            return newBB;
        }
            
        public function PLUS( other:Bitboard64 ) : Void
        {	
            var overflow:Int = ((lower & 0xFFFF) + (other.lower & 0xFFFF)) >> 16;			
            overflow += (lower >>> 16) + (other.lower >>> 16);
            upper += other.upper;
            lower += other.lower;
            
            if( (overflow & 0x10000) != 0 )
            {
                upper++;
            }		
            needCount = true;	
        }
        
        public function newPLUS( other:Bitboard64 ) : Bitboard64 
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.PLUS( other );
            return newBB;
        }
        
        public function MINUS( other:Bitboard64 ) : Void
        {
            var notLower:Int = ~other.lower + 1;
            var notUpper:Int = ~other.upper;
            
            var overflow:Int = ((lower & 0xFFFF) + (notLower & 0xFFFF)) >>> 16;			
            overflow += (lower >>> 16) + (notLower >>> 16);
            upper += notUpper;
            lower += notLower;
            
            if( (overflow & 0x10000) != 0 )
            {
                upper++;
            }		
            needCount = true;	
        }
        
        public function newMINUS( other:Bitboard64 ) : Bitboard64	
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.MINUS( other );
            return newBB;
        }
        
            
        public function PopLSB() : Int
        {
            var index:Int = -1;		
            if( lower != 0 )
            {
                count--;
                index = LeastSB( lower );
                lower &= lower - 1; 
                return index;
            }
            if( upper != 0 )
            {
                count--;
                index = 32 + LeastSB( upper );
                upper &= upper - 1;  		
                return index;
            }		
            return -1;
        }
        
        public function LSB() : Int
        {
            if( lower != 0 ) { return LeastSB( lower );	}
            if( upper != 0 ) { return LeastSB( upper ) + 32; }
            return -1;
        }
        
        public function MSB() : Int
        {		
            if( upper != 0 ) { return MostSB( upper ) + 32; }
            if( lower != 0 ) { return MostSB( lower );	}
            return -1;
        }
            
        public static function LeastSB( theInt:Int ) : Int
        {
            var i:Int = -1;
            if( (theInt & 0x0000ffff) == 0 ) { i += 16; theInt >>>= 16; } // 11111111111111110000000000000000
            if( (theInt & 0x000000ff) == 0 ) { i +=  8; theInt >>>=  8; } // 00000000000000001111111100000000
            if( (theInt & 0x0000000f) == 0 ) { i +=  4; theInt >>>=  4; } // 00000000000000000000000011110000
            if( (theInt & 0x00000003) == 0 ) { i +=  2; theInt >>>=  2; } // 00000000000000000000000000001100
            if( (theInt & 0x00000001) == 0 ) { i +=  1; theInt >>>=  1; } // 00000000000000000000000000000010
            if( (theInt & 0x00000001) != 0 ) { i +=  1; }
            
            return i;
        }
        
        public static function MostSB( theInt:Int ) : Int
        {
            var i:Int = -1;
            if( (theInt & 0xffff0000) != 0 ) { i += 16; theInt >>>= 16; } // 11111111111111110000000000000000
            if( (theInt & 0x0000ff00) != 0 ) { i +=  8; theInt >>>=  8; } // 00000000000000001111111100000000
            if( (theInt & 0x000000f0) != 0 ) { i +=  4; theInt >>>=  4; } // 00000000000000000000000011110000
            if( (theInt & 0x0000000c) != 0 ) { i +=  2; theInt >>>=  2; } // 00000000000000000000000000001100
            if( (theInt & 0x00000003) != 0 ) { i +=  1; theInt >>>=  1; } // 00000000000000000000000000000010
            if( (theInt & 0x00000001) != 0 ) { i +=  1; }
            
            return i;			
        }
        
        public function ShiftL( theShift:Int ) : Void
        {		
            if( theShift < 32 ) 
            { 
                upper = upper << theShift;
                upper |= (lower >>> (32 - theShift)); 
                lower = lower << theShift;
            }
            else 
            {
                upper = (lower << (theShift - 32)); 
                lower = 0;
            }		
            needCount = true;
        }
        
        public function newShiftL( theShift:Int ) : Bitboard64	
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.ShiftL( theShift );
            return newBB;
        }
        
        public function ShiftR( theShift:Int ) : Void
        {			
            if( theShift < 32 )
            {
                lower = lower >>> theShift;
                lower |= ( ((upper << (32-theShift)) >>> (32 - theShift)) << (32 - theShift) );
                upper = upper >>> theShift;
            }
            else
            {
                lower = (upper >>> (theShift - 32));
                upper = 0;
            }
            needCount = true;
        }
        
        public function newShiftR( theShift:Int ) : Bitboard64
        {
            var newBB:Bitboard64 = new Bitboard64();
            newBB.Copy( this );
            newBB.ShiftR( theShift );
            return newBB;
        }
        
        
        
        
        public function SetBit( theIndex:Int ) : Void
        {
            if( theIndex < 32 )
            {
                lower |= (1 << theIndex);
            }
            else
            {
                upper |= (1 << (theIndex-32));
            }
            needCount = true;
        }
        
        public function ClrBit( theIndex:Int ) : Void
        {
            if( theIndex < 32 )
            {
                lower ^= (1 << theIndex);
            }
            else
            {
                upper ^= (1 << (theIndex-32));
            }
            needCount = true;
        }
        
        
        public function IsSet( theIndex:Int ) : Bool
        {
            if( theIndex < 32 )
            {	
                if( (lower & (1 << theIndex)) != 0 )
                {
                    return true;
                }
            }
            else
            {
                if( (upper & (1 << (theIndex-32))) != 0 )
                {
                    return true;
                }
            }
            return false;
        }
        
        
        public function IsZero() : Bool
        {
            if( lower == 0 && upper == 0 )
            {
                return true;
            }
            return false;
        }
        
        public function IsNonZero() : Bool
        {
            if( lower != 0 || upper != 0 )
            {
                return true;
            }
            return false;
        }
    
        public function MoreThanOne() : Bool
        {
            if( (lower & (lower - 1)) != 0 || 
                (upper & (upper - 1)) != 0 ||
                (lower != 0 && upper != 0) )
            {
                return true;
            }				
            return false;
        }	
        
        
        public function Count() : Int
        {
            if( needCount )
            {
                needCount = false;
                count = BitCount( upper ) + BitCount( lower );
            }
            return count;
        }
        
        public static function BitCount( theInt:Int ) : Int
        {		
            var total:Int = 0;
            while( theInt != 0 )
            {
                  theInt &= theInt - 1; 
                  total++;
            }
            return total;
        }
            
        
        // public function Multi( other:Bitboard64 ) : Void
        // {
        //     var a1:Int = (lower & 0xFFFF);
        //     var a2:Int = (lower >>> 16);
        //     var a3:Int = (upper & 0xFFFF);
        //     var a4:Int = (upper >>> 16);
        //     var b1:Int = (other.lower & 0xFFFF);
        //     var b2:Int = (other.lower >>> 16);
        //     var b3:Int = (other.upper & 0xFFFF);
        //     var b4:Int = (other.upper >>> 16);
            
                
        //      var dL1:Float = a1 * b1;
        //       var dL2:Float = a2 * b1 + b2 * a1 + ((dL1 >>> 16) & 0xFFFF);	
                        
        //       var dL3:Float = a3 * b1 + b3 * a1 + a2 * b2 + ((dL2 >>> 16) & 0xFFFF);
        //       if( dL2 > uint.MAX_VALUE )
        //       {
        //           dL3 += (1 << 16);
        //       }
              
        //       var dL4:Float = a3 * b2 + b3 * a2 + a4 * b1 + b4 * a1 + ((dL3 >>> 16) & 0xFFFF);
        //       if( dL3 > uint.MAX_VALUE )
        //       {
        //         dL4 += (1 << 16);
        //       }
              
                      
        //       var d1:Int = Std.int(dL1 & 0xFFFF);
        //       var d2:Int = Std.int(dL2 & 0xFFFF);
        //       var d3:Int = Std.int(dL3 & 0xFFFF);
        //       var d4:Int = Std.int(dL4 & 0xFFFF);
              
        //       lower = (d1 & 0xFFFF) | ((d2 & 0xFFFF) << 16);
        //       upper = (d3 & 0xFFFF) | ((d4 & 0xFFFF) << 16);
        //       needCount = true;
        //  }
        
        // public function newMultiply( other:Bitboard64 ) : Bitboard64	
        // {
        //     var newBB:Bitboard64 = new Bitboard64();
        //     newBB.Copy( this );
        //     newBB.Multi( other );
        //     return newBB;
        // }
        
        	// Todo:あとで直す
	public function MULTI(times:Int):Void {
		for(t in 0...times) {
			this.PLUS(this.newCOPY());
		}
	}

	public function newMULTI(times:Int):Bitboard64 {
		var newBB:Bitboard64 = new Bitboard64();
		newBB.Copy(this);
		newBB.MULTI(times);
		return newBB;
	}
        
        public function ToString() : String
        {
            var newString:String = "";
            for( i in 0...64)
            {
                if( IsSet( 63 - i ) )
                {
                    newString += "1";
                }
                else
                {
                    newString += "0";
                }
            }
        
            return newString + " " + Count();
        }
        
        public function toStringBB() : String
        {
            var string:String = "";
            for( i in 0...64 )
            {
                if( i > 0 && (i % 8 == 0) )
                {
                    string += "\n";
                }
                
                var file:Int = i % 8;
                var rank:Int = 7 - (i >>> 3);
                
                if( IsSet( file + (rank << 3) ) )
                {
                    string += "1";
                }
                else
                {
                    string += "0";
                }			
            }
            return string;
        }
        
        
        public static function ToStringBB2( b1:Bitboard64, b2:Bitboard64 ) : String
        {
            var string:String = "";
                    var file:Int = 0;
                    var rank:Int = 0;
            for( j in 0...8 )
            {
                for( i in 0...8 )
                {
                    file = i;
                    rank = 7 - j;
                
                    if( b1.IsSet( file + (rank << 3) ) )
                    {
                        string += "1";
                    }
                    else
                    {
                        string += "0";
                    }			
                    
                    if( file == 7) 
                    {
                        string += " ";
                    }
                }
                
                for( i in 0...8)
                {
                    file = i;
                    rank = 7 - j;
                    
                    if( b2.IsSet( file + (rank << 3) ) )
                    {
                        string += "1";
                    }
                    else
                    {
                        string += "0";
                    }			
                    
                    if( file == 7) 
                    {
                        string += "\n";
                    }
                }
            }
            return string;
        }
        
        
        public static function ToStringBB8( b1:Bitboard64, b2:Bitboard64, b3:Bitboard64, b4:Bitboard64,
                                            b5:Bitboard64, b6:Bitboard64, b7:Bitboard64, b8:Bitboard64 ) : String
        {
            var string:String = "";
            for( j in 0...8 )
            {
                for( k in 0...8 )
                {
                    var bb:Bitboard64 = b1;
                    if( k == 1 ) { bb = b2; }
                    if( k == 2 ) { bb = b3; }
                    if( k == 3 ) { bb = b4; }
                    if( k == 4 ) { bb = b5; }
                    if( k == 5 ) { bb = b6; }
                    if( k == 6 ) { bb = b7; }
                    if( k == 7 ) { bb = b8; }
                    
                    for( i in 0...8 )
                    {
                        var file:Int = i;
                        var rank:Int = 7 - j;
                    
                        if( bb.IsSet( file + (rank << 3) ) )
                        {
                            string += "1";
                        }
                        else
                        {
                            string += "0";
                        }			
                        
                        if( file == 7 && k < 7 ) 
                        {
                            string += " ";
                        }
                        if( file == 7 && k == 7 ) 
                        {
                            string += "\n";
                        }
                    }
                }			
            }
            return string;
        }
            
    }
    