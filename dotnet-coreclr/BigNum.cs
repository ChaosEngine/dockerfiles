using System;

namespace CSBigNum
{
	class Err : Exception
	{
		public String m_pszStr;
    
		public Err()
		{
			m_pszStr = "No Err";
		}
		public Err(String pszErrStr)
		{
			m_pszStr = pszErrStr;
		}
		public void SetErrStr(String pStr)
		{
			m_pszStr = pStr;
		}
		public void Print()
		{
			Console.WriteLine(m_pszStr);
		}
	};

	class BigNum
	{
		private char[]				m_pszNum = null;
		private int					m_iSize;
		private bool				m_bIsValid;
		public static Err			m_Err;
		public const int			MAX_NUM_STR = 32;

		private void CleanAndBalance()
		{
			/************************************************************************
			   000226568	=>	226568
			   ^^^^^^^^^		^^^^^^
			   badokokok		okokok
			************************************************************************/

			int i = 0, first_not_null = 0;
			while(i < m_iSize && m_pszNum[i] == '0')
				i++;
			first_not_null = i;

			int j = first_not_null;
			i = 0;
			while(j < m_iSize && i < m_iSize)
			{
				m_pszNum[i] = m_pszNum[j];
				i++; j++;
			}
			if(i == 0)	i++;		//handle single 0 case
			m_pszNum[i] = Convert.ToChar(0);
			m_iSize = i;
		}
		private int GetDigitAt(int iPos)
		{
			if(iPos >= 0 && iPos < m_iSize)
			{
				return m_pszNum[iPos] - Convert.ToChar('0');
			}
			else
			{
				m_Err = new Err("Error: bad index");
				return 0;
			}
		}
		public BigNum()
		{
			m_pszNum = null;
			m_bIsValid = false;
			m_iSize = 1;

			m_pszNum = new char[m_iSize + 1];	//add '\0' character
			if(m_pszNum == null)
				throw new Err("Error: Could not allocate mem!");

			for(int i = 0; i < m_iSize; i++)
				m_pszNum[i] = '0';
			//end line character
			m_pszNum[m_iSize] = Convert.ToChar(0);

			m_bIsValid = true;
		}
		public BigNum(int iSize)
		{
			m_pszNum = null;
			m_bIsValid = false;

			if(iSize <= 0 || iSize > MAX_NUM_STR)
				throw new Err("Error: To big or bad initial size!");	
			m_iSize = iSize;

			m_pszNum = new char[m_iSize + 1];	//add '\0' character
			if(m_pszNum == null)
				throw new Err("Error: Could not allocate mem!");

			for(int i = 0; i < m_iSize; i++)
				m_pszNum[i] = '0';
			//end line character
			m_pszNum[m_iSize] = Convert.ToChar(0);

			m_bIsValid = true;
		}
		public BigNum(String sNumStr)
		{
			m_pszNum = null;
			m_bIsValid = false;

			int iSize = sNumStr.Length;
			if(iSize <= 0 || iSize > MAX_NUM_STR)
				throw new Err("Error: Bad initial size");

			m_iSize = iSize;
			m_pszNum = new char[m_iSize + 1];	//add '\0' character
			if(m_pszNum == null)
				throw new Err("Could not allocate mem!");

			for(int i = 0; i < m_iSize; i++)
			{
				m_pszNum[i] = '0';
				if( Char.IsDigit(sNumStr[i]) == true)
					m_pszNum[i] = sNumStr[i];
			}
			//end line character
			m_pszNum[m_iSize] = Convert.ToChar(0);

			m_bIsValid = true;
		}
		public BigNum(ref BigNum Obj)
		{
			m_pszNum = null;
			m_bIsValid = false;

			m_iSize = Obj.m_iSize;
			m_pszNum = new char[m_iSize + 1];
			if(m_pszNum == null)
				throw new Err("Error: Could not allocate mem!");

			for(int i = 0; i < m_iSize; i++)
			{
				m_pszNum[i] = Obj.m_pszNum[i];
			}
			m_pszNum[m_iSize] = Convert.ToChar(0);
			m_bIsValid = true;
		}
		/*~BigNum()
		{
			//Console.WriteLine("destruction");
		}*/
		public static bool IsValid(BigNum Obj)
		{
			if(Obj == null || !Obj.m_bIsValid)
			{
				m_Err = new Err("Error: bad object!");
				m_Err.Print();
				return false;
			}
			return true;
		}
		public bool IsValid()
		{
			return IsValid(this);
		}
		public char[] GetNumStr()
		{
			return m_pszNum;
		}
		//decimal shift left
		public static BigNum operator<<(BigNum Left, int iRight)
		{
			if(iRight <= 0)
			{
				//TODO:Check if that really is an error
				m_Err = new Err("Error: Bad shift argument");
				return Left;
			}
			int shift = Math.Min(MAX_NUM_STR, iRight);

			BigNum ret = new BigNum(Left.m_iSize + shift);

			int i = 0;
			for(; i < ret.m_iSize; i++)
			{
				ret.m_pszNum[i] = '0';
				if(i < Left.m_iSize)
					ret.m_pszNum[i] = Left.m_pszNum[i];
			}
			ret.m_pszNum[i] = Convert.ToChar(0);

			return ret;
		}
		public static BigNum operator+(BigNum Left, BigNum Right)
		{
			if( /*!IsValid(this) || */!IsValid(Right) )
				return Left;

			/************************************************************************
				9999   9999999
			  + 9999  +   9999
			  ^^^^^^^ ^^^^^^^^
			   19998  10009998
			************************************************************************/
			int max_size;
			char[] big_str, small_str;
			int si, bi;
			//selecting longer string and set index sizes
			if(Left.m_iSize >= Right.m_iSize)
			{
				max_size = Left.m_iSize;
				big_str = Left.m_pszNum;
				small_str = Right.m_pszNum;
				bi = Left.m_iSize - 1;
				si = Right.m_iSize - 1;		
			}
			else
			{
				max_size = Right.m_iSize;
				big_str = Right.m_pszNum;
				small_str = Left.m_pszNum;
				bi = Right.m_iSize - 1;
				si = Left.m_iSize - 1;
			}	
			BigNum ret = new BigNum(max_size + 1);		//return BigNum
			char[] sum_str = ret.m_pszNum;	//sum string => ret string    
			int mi = max_size;

			int overflow = 0;
			for(; mi >= 0; si--, bi--, mi--)
			{
				int sum = 0;
				if( si >= 0)
				{	//traverse both strings
					sum = Convert.ToInt32(big_str[bi]) + Convert.ToInt32(small_str[si]) - (2 * Convert.ToInt32('0'));

					sum_str[mi] = Convert.ToChar( (sum + overflow) % 10 + Convert.ToInt32('0') );
					overflow = (sum + overflow) / 10;
				}
				else if(bi >= 0)
				{	//add single reminding overflow and copy the rest of big_str
					sum = Convert.ToInt32(big_str[bi]) - Convert.ToInt32('0') + overflow;
					sum_str[mi] = Convert.ToChar( sum % 10 + Convert.ToInt32('0') );
					overflow = sum / 10;
				}
				else
				{	//add last reminding overflow if any and exit loop
					sum_str[mi] = Convert.ToChar( overflow + '0' );
					break;
				}
			}
			ret.CleanAndBalance();
	
			return ret;
		}
		public static BigNum operator*(BigNum Left, int iRight)
		{
			if(iRight > 9)
			{
				m_Err = new Err("Error: Bad argument");
				return Left;
			}
	
			BigNum ret = new BigNum(Left.m_iSize + 1);
			char[] small_str = Left.m_pszNum;
			char[] sum_str = ret.m_pszNum;

			int mi = Left.m_iSize;
			int si = Left.m_iSize - 1;
			int overflow = 0;
			for(; mi >= 0; si--, mi--)
			{
				int sum = 0;
				if( si >= 0)
				{	//traverse both strings
					sum = (Convert.ToInt32(small_str[si]) - Convert.ToInt32('0')) * iRight + overflow;

					sum_str[mi] = Convert.ToChar( sum % 10 + Convert.ToInt32('0') );
					overflow = sum / 10;
				}
				else
				{	//add last reminding overflow if any and exit loop
					sum_str[mi] = Convert.ToChar( overflow + '0' );
					break;
				}
			}
			ret.CleanAndBalance();

			return ret;
		}
		public static BigNum operator*(BigNum Left, BigNum Right)
		{
			if( /*!IsValid(this) || */!IsValid(Right) )
				return Left;

			BigNum big = null, small = null;
			int si;
			//selecting longer string and set index sizes
			if(Left.m_iSize >= Right.m_iSize)
			{
				si = Right.m_iSize - 1;
				big = Left;
				small = Right;
			}
			else
			{
				si = Left.m_iSize - 1;
				big = Right;
				small = Left;
			}

			BigNum ret = new BigNum("0"), tmp;
			for(int shift_count = 0; si >= 0; si--, shift_count++)
			{
				int multiplier_num = small.GetDigitAt(si);

				//ret = ret + ( (*big * multiplier_num) << shift_count );		//2 extreme ;-)
				tmp = big * multiplier_num;
				tmp = tmp << shift_count;
				ret = ret + tmp;
			}

			return ret;
		}
		public void Print()
		{
			if(IsValid())
				Console.WriteLine(this.m_pszNum);
			else
			{
				Err e = new Err("Err: Bad Object");
				e.Print();
			}
		}
		public override String ToString()
		{
			return new String(m_pszNum);
		}
		static bool TestBigNumAdd(int iCount, bool bMode)
		{
			String bufa = null;
			String bufb = null;
			String bufc = null;

			Random rand = new System.Random();

			for(int i = 0; i < iCount; i++)
			{
				int ia = /*Math.Abs(*/rand.Next()/*)*/ % 10000;
				int ib = /*Math.Abs(*/rand.Next()/*)*/ % 10000;

				/*sprintf(bufa, "%u", ia);
				sprintf(bufb, "%u", ib);*/
				bufa = ia.ToString();
				bufb = ib.ToString();

				BigNum a = new BigNum(bufa);
				BigNum b = new BigNum(bufb);

				BigNum c;
				c = a + b;
				int ic = ia + ib;

				if(bMode)
					//cout << "ia = " << ia << " ib = " << ib << " ic = " << ic << " c = " << c;
					Console.WriteLine("ia = {0} ib = {1} ic = {2} c = {3}", ia, ib, ic, c);

				//sprintf(bufc, "%u", ic);
				bufc = ic.ToString();
				int strcmp_res = 0;
				strcmp_res = bufc.CompareTo(c.ToString());

				if(strcmp_res != 0)
				{
					/*cerr << "\nTestBigNum bad!\nia = " << ia << " ib = " << ib
						<< " ic = " << ic << endl;*/
					Console.Error.WriteLine("\nTestBigNum bad!\nia = {0} ib = {1} ic = {2}", ia, ib, ic);
					return false;
				}
				if(bMode)
					//cout << " bufc = " << bufc << " strcmp_res = " << strcmp_res << endl;
					Console.WriteLine("bufc = {0} strcmp_res = {1}", bufc, strcmp_res);
			}

			Console.WriteLine("TestBigNum ok!");

			return true;
		}
		static bool TestBigNumMul(int iCount, bool bMode)
		{
			String bufa = null;
			String bufb = null;
			String bufc = null;

			Random rand = new System.Random();

			for(int i = 0; i < iCount; i++)
			{
				int ia = /*Math.Abs(*/rand.Next()/*)*/ % 10000;
				int ib = /*Math.Abs(*/rand.Next()/*)*/ % 10000;

				/*sprintf(bufa, "%u", ia);
				sprintf(bufb, "%u", ib);*/
				bufa = ia.ToString();
				bufb = ib.ToString();

				BigNum a = new BigNum(bufa);
				BigNum b = new BigNum(bufb);

				BigNum c;
				c = a * b;
				int ic = ia * ib;

				if(bMode)
					//cout << "ia = " << ia << " ib = " << ib << " ic = " << ic << " c = " << c;
					Console.WriteLine("ia = {0} ib = {1} ic = {2} c = {3}", ia, ib, ic, c);

				//sprintf(bufc, "%u", ic);
				bufc = ic.ToString();
				int strcmp_res = 0;
				strcmp_res = bufc.CompareTo(c.ToString());

				if(strcmp_res == 0)
				{
					/*cerr << "\nTestBigNum bad!\nia = " << ia << " ib = " << ib
						<< " ic = " << ic << " c = " << c <<endl;*/
					Console.Error.WriteLine("\nTestBigNum bad!\nia = {0} ib = {1} ic = {2} c = {3}", ia, ib, ic, c);
					return false;
				}
				if(bMode)
					//cout << " bufc = " << bufc << " cmp = " << strcmp_res << endl;
					Console.WriteLine("bufc = {0} strcmp_res = {1}", bufc, strcmp_res);
			}

			Console.WriteLine("TestBigNum ok!");

			return true;
		}
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static int Main(string[] sArgs)
		{
			BigNum pObj = null;

			try
			{
				pObj = new BigNum(32);
			}
			catch(Err e)
			{
				e.Print();
				return 1;
			}
			BigNum tst = new BigNum("ala ma kota193aa4536dgg");
			BigNum cpy = new BigNum(ref tst);
	
			Console.WriteLine("pObj = {0}", new String(pObj.GetNumStr()));
			Console.WriteLine("tst  = {0}", new String(tst.GetNumStr()));
			Console.WriteLine("cpy  = {0}\n", new String(cpy.GetNumStr()));

			BigNum a, b, c;
			a = new BigNum("2050450694");
			b = new BigNum("1459174955");
			c = new BigNum();

			Console.WriteLine("a = {0} b = {1} c = {2}", new String(a.GetNumStr()), new String(b.GetNumStr()),
				new String(c.GetNumStr()));

			c = a * b;

			Console.WriteLine("c = {0}", new String(c.GetNumStr()));

			int start = System.Environment.TickCount;

			//TestBigNumAdd(10000000/*count*/, false);
			TestBigNumMul(1000000/*count*/, false);

			Console.WriteLine("Calculated in {0} milliseconds", System.Environment.TickCount - start);

			return 0;
		}
	}
}
