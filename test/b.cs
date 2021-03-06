namespace Language.CSharp
{
    public class Class
    {
        public void Method(int a, double b)
        {
            // booleans
            bool m, n = false, @void = true;

            // numbers
            float x = 101.2e10, y = 10, z = .1e-6;
            decimal d = 101.6m;
            long l = 60lU;

            // characters
            char c = 'a', c2 = '@', c3 = '*';
            char c5 = '\x123', c6 = '\u1234', c7 = '\U12345678';
            char c10 = '\\', c11 = '\'';

            // some strings
            string simple = "this is a simple string";
            string txt = "this is \r \n \t \b \a \v \" woooo";
            string vb1 = @"abc";
            string vb2 = @"abc ""def"" ghi";
            string vb = @"
    ""a""
         ""verbatim""
                     ""string!""

       \r\n\t\b\a\v\";

            // arrays
            int[,,][,][] xs = null;

            // simple name
            var f = MyFunction<A, B, C>;

            // parens
            int z = (1);

            // member access
            var x = (Simple<T>).Member<T>;

            // invocation
            Test123 z = x.Property.Invoke().MethodCall<A, B>(a, ref b, out c);
            Lang.MyClass<int, B> x = AnotherMethod(true, 10.1m, 'x');

            // element access
            var z1 = xs[0];
            var z2 = x.GetArray()[x.BestIndex()];
            var z3 = x.Rank2Please()[abc, x.ElementAccess()];

            // this access
            var z3 = this;
            var z4 = this[10];

            // base access
            var b1 = base.MemberAccess();
            var b2 = base[123, z.ElementAccess];

            // post increment/decrement
            var inc = i++;
            var dec = d--;

            // object creation
            List<int> xs = new List<int>(106, "whee");
            Person obj = new Person { Name = "Fred" };
            Boat b = new Boat("yeah", 1) { ImOnIt = true,
                                           Nested = { Yes = { It = { Is = true } } } };
            List<int> xs = new List<int> { 1, 2, 3 };
            var d = new Dictionary<string, string> { { "A", "Alpha" },
                                                     { "B", "Bravo" },
                                                     { "C", "Charlie" } };
        }
#if 0
#  error :(
#endif

        #region SomeHorribleRegion

        public Lang.MyClass<int, B> AnotherMethod(bool b, decimal d, char c)
        {
        }

        #endregion
    }
}
