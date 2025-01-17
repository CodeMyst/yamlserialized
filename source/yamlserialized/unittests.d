module yamlserialized.unittests;

unittest {
    import yamlserialized : YamlField, toYAMLNode, deserializeInto;
    import dunit.toolkit : assertEqual;

    class Test {
        @YamlField("some_field")
        string someField;

        public this() {
            Test ts = new Test("something other");
            auto node = ts.toYAMLNode();

            node.deserializeInto(this);
        }

        public this(string f) {
            this.someField = f;
        }
    }

    Test ts1 = new Test();

    assertEqual(ts1.someField, "something other");
}

unittest {
    import yamlserialized : YamlField, toYAMLNode, deserializeInto;
    import dunit.toolkit : assertEqual;

    struct Test {
        @YamlField("some_field")
        string someField;
    }

    Test ts = Test("hello world");

    auto node = ts.toYAMLNode();

    assertEqual(node["some_field"], "hello world");

    Test ts1;

    node.deserializeInto(ts1);

    assertEqual(ts1.someField, "hello world");
}

unittest {
    import std.conv : to;
    import dunit.toolkit : assertEqual;
    import dyaml : Loader;

    import yamlserialized : deserializeInto, deserializeTo, toYAMLNode;

    struct TestSubStruct {
        int anotherInt;
        string anotherString;
    }

    struct TestStruct {
        struct NestedStruct {
            int nestedInt;
            string nestedString;
        }

        int singleInt;
        float singleFloat;
        int[] intArray;
        int[][] arrayOfIntArrays;
        int[string] intStringAssocArray;
        int[int] intIntAssocArray;
        char singleChar;
        char[] charArray;
        string singleString;
        string[] stringArray;
        string[][] arrayOfStringArrays;
        string[string] stringAssocArray;
        string[string][string] stringAssocArrayOfAssocArrays;
        bool trueBool;
        bool falseBool;

        TestSubStruct subStruct;
        NestedStruct nestedStruct;
        NestedStruct[] arrayOfNestedStructs;
        NestedStruct[string] nestedStructAssocArray;
    }

    // Create test struct and set it up with some test values
    TestStruct ts;
    with (ts) {
        singleInt = 1234;
        singleFloat = 1.234;
        intArray = [1, 2, 3, 4];
        arrayOfIntArrays = [[1, 2], [3, 4]];
        intStringAssocArray = ["one": 1, "two": 2, "three": 3];
        intIntAssocArray = [1: 3, 2: 1, 3: 2];
        singleChar = 'A';
        charArray = ['A', 'B', 'C', 'D'];
        singleString = "just a string";
        stringArray = ["a", "few", "strings"];
        arrayOfStringArrays = [["a", "b"], ["c", "d"]];
        stringAssocArray = ["a": "A", "b": "B", "c": "C"];
        stringAssocArrayOfAssocArrays = ["a": ["a": "A", "b": "B"], "b": ["c": "C", "d": "D"]];
        trueBool = true;
        falseBool = false;
        subStruct.anotherInt = 42;
        subStruct.anotherString = "Another string";
        nestedStruct.nestedInt = 53;
        nestedStruct.nestedString = "Nested string";
        arrayOfNestedStructs = [NestedStruct(1, "One"), NestedStruct(2, "Two")];
        nestedStructAssocArray = ["one": NestedStruct(1, "One"), "two": NestedStruct(2, "Two")];
    }

    // Serialize the struct to YAML
    auto node = ts.toYAMLNode();

    // Create a new empty struct
    TestStruct ts2;

    // Deserialize the JSONValue into it
    node.deserializeInto(ts2);

    // Assert that both structs are identical
    assertEqual(ts2.singleInt, ts.singleInt);
    assertEqual(ts2.singleFloat, ts.singleFloat);
    assertEqual(ts2.intArray, ts.intArray);
    assertEqual(ts2.arrayOfIntArrays, ts.arrayOfIntArrays);
    assertEqual(ts2.intStringAssocArray, ts.intStringAssocArray);
    assertEqual(ts2.intIntAssocArray, ts.intIntAssocArray);
    assertEqual(ts2.singleChar, ts.singleChar);
    assertEqual(ts2.charArray, ts.charArray);
    assertEqual(ts2.singleString, ts.singleString);
    assertEqual(ts2.stringArray, ts.stringArray);
    assertEqual(ts2.arrayOfStringArrays, ts.arrayOfStringArrays);
    assertEqual(ts2.stringAssocArray, ts.stringAssocArray);
    assertEqual(ts2.stringAssocArrayOfAssocArrays, ts.stringAssocArrayOfAssocArrays);
    assertEqual(ts2.trueBool, ts.trueBool);
    assertEqual(ts2.falseBool, ts.falseBool);
    assertEqual(ts2.subStruct, ts.subStruct);
    assertEqual(ts2.subStruct.anotherInt, ts.subStruct.anotherInt);
    assertEqual(ts2.subStruct.anotherString, ts.subStruct.anotherString);
    assertEqual(ts2.nestedStruct, ts.nestedStruct);
    assertEqual(ts2.nestedStruct.nestedInt, ts.nestedStruct.nestedInt);
    assertEqual(ts2.nestedStruct.nestedString, ts.nestedStruct.nestedString);
    assertEqual(ts2.arrayOfNestedStructs, ts.arrayOfNestedStructs);
    assertEqual(ts2.arrayOfNestedStructs[0].nestedInt, ts.arrayOfNestedStructs[0].nestedInt);
    assertEqual(ts2.arrayOfNestedStructs[0].nestedString, ts.arrayOfNestedStructs[0].nestedString);
    assertEqual(ts2.arrayOfNestedStructs[1].nestedInt, ts.arrayOfNestedStructs[1].nestedInt);
    assertEqual(ts2.arrayOfNestedStructs[1].nestedString, ts.arrayOfNestedStructs[1].nestedString);
    assertEqual(ts2.nestedStructAssocArray, ts.nestedStructAssocArray);
    assertEqual(ts2.nestedStructAssocArray["one"].nestedInt, ts.nestedStructAssocArray["one"].nestedInt);
    assertEqual(ts2.nestedStructAssocArray["two"].nestedString, ts.nestedStructAssocArray["two"].nestedString);

    // Attempt to deserialize partial YAML
    TestStruct ts3;
    Loader.fromString(`{ singleInt: 42, singleString: "Don't panic." }`.to!(char[])).load().deserializeInto(ts3);

    ts3.singleInt.assertEqual(42);
    ts3.singleString.assertEqual("Don't panic.");

    // Attempt to deserialize YAML containing a property that does not exist in the struct
    TestStruct ts4;
    Loader.fromString(`{ nonexistentString: "Move along, nothing to see here." }`.to!(char[])).load().deserializeInto(ts4);

    auto ts5 = Loader.fromString(`{ singleInt: 42, singleString: "Don't panic." }`.to!(char[])).load().deserializeTo!TestStruct;
    ts5.singleInt.assertEqual(42);
    ts5.singleString.assertEqual("Don't panic.");
}


unittest {
    import dunit.toolkit : assertEqual;
    import dyaml : Loader;

    import yamlserialized : deserializeInto, toYAMLNode;

    class TestSubClass {
        int anotherInt;
        float anotherFloat;
    }

    class TestClass {
        static class NestedClass {
            int nestedInt;
            float nestedFloat;

            pure this() {
            }

            this(in int initInt, in float initFloat) {
                nestedInt = initInt;
                nestedFloat = initFloat;
            }
        }

        int singleInt;
        float singleFloat;
        int[] intArray;
        int[][] arrayOfIntArrays;
        int[string] intStringAssocArray;
        int[int] intIntAssocArray;
        char singleChar;
        char[] charArray;
        string singleString;
        string[] stringArray;
        string[][] arrayOfStringArrays;
        string[string] stringAssocArray;
        string[string][string] stringAssocArrayOfAssocArrays;
        NestedClass[] arrayOfNestedClasses;
        NestedClass[string] nestedClassAssocArray;

        auto subClass = new TestSubClass();
        auto nestedClass = new NestedClass(53, 5.3);
    }

    // Create test struct and set it up with some test values
    auto tc = new TestClass();
    with (tc) {
        singleInt = 1234;
        singleFloat = 1.234;
        intArray = [1, 2, 3, 4];
        arrayOfIntArrays = [[1, 2], [3, 4]];
        intStringAssocArray = ["one": 1, "two": 2, "three": 3];
        intIntAssocArray = [1: 3, 2: 1, 3: 2];
        singleChar = 'A';
        charArray = ['A', 'B', 'C', 'D'];
        singleString = "just a string";
        stringArray = ["a", "few", "strings"];
        arrayOfStringArrays = [["a", "b"], ["c", "d"]];
        stringAssocArray = ["a": "A", "b": "B", "c": "C"];
        stringAssocArrayOfAssocArrays = ["a": ["a": "A", "b": "B"], "b": ["c": "C", "d": "D"]];
        arrayOfNestedClasses = [new NestedClass(1, 1.2), new NestedClass(2, 2.3)];
        nestedClassAssocArray = ["one": new NestedClass(1, 1.2), "two": new NestedClass(2, 2.3)];
        subClass.anotherInt = 42;
        subClass.anotherFloat = 4.2;
    }

    // Serialize the struct to a Node
    auto node = tc.toYAMLNode();

    // Create a new empty struct
    auto tc2 = new TestClass();

    // Deserialize the node into it
    node.deserializeInto(tc2);

    // Assert that both structs are identical
    assertEqual(tc2.singleInt, tc.singleInt);
    assertEqual(tc2.singleFloat, tc.singleFloat);
    assertEqual(tc2.intArray, tc.intArray);
    assertEqual(tc2.arrayOfIntArrays, tc.arrayOfIntArrays);
    assertEqual(tc2.intStringAssocArray, tc.intStringAssocArray);
    assertEqual(tc2.intIntAssocArray, tc.intIntAssocArray);
    assertEqual(tc2.singleChar, tc.singleChar);
    assertEqual(tc2.charArray, tc.charArray);
    assertEqual(tc2.singleString, tc.singleString);
    assertEqual(tc2.stringArray, tc.stringArray);
    assertEqual(tc2.arrayOfStringArrays, tc.arrayOfStringArrays);
    assertEqual(tc2.stringAssocArray, tc.stringAssocArray);
    assertEqual(tc2.stringAssocArrayOfAssocArrays, tc.stringAssocArrayOfAssocArrays);
    assertEqual(tc2.subClass.anotherInt, tc.subClass.anotherInt);
    assertEqual(tc2.subClass.anotherFloat, tc.subClass.anotherFloat);
    assertEqual(tc2.nestedClass.nestedInt, tc.nestedClass.nestedInt);
    assertEqual(tc2.nestedClass.nestedFloat, tc.nestedClass.nestedFloat);
    assertEqual(tc2.arrayOfNestedClasses[0].nestedInt, tc.arrayOfNestedClasses[0].nestedInt);
    assertEqual(tc2.arrayOfNestedClasses[0].nestedFloat, tc.arrayOfNestedClasses[0].nestedFloat);
    assertEqual(tc2.arrayOfNestedClasses[1].nestedInt, tc.arrayOfNestedClasses[1].nestedInt);
    assertEqual(tc2.arrayOfNestedClasses[1].nestedFloat, tc.arrayOfNestedClasses[1].nestedFloat);
    assertEqual(tc2.nestedClassAssocArray["one"].nestedInt, tc.nestedClassAssocArray["one"].nestedInt);
    assertEqual(tc2.nestedClassAssocArray["one"].nestedFloat, tc.nestedClassAssocArray["one"].nestedFloat);
    assertEqual(tc2.nestedClassAssocArray["two"].nestedInt, tc.nestedClassAssocArray["two"].nestedInt);
    assertEqual(tc2.nestedClassAssocArray["two"].nestedFloat, tc.nestedClassAssocArray["two"].nestedFloat);
}

unittest {
    import std.conv : to;
    import dunit.toolkit;
    import dyaml;

    import yamlserialized : deserializeInto;

    string[string] aa;
    auto node = Loader.fromString(`{ aString: theString, anInt: 42 }`.to!(char[])).load();

    node.deserializeInto(aa);

    assertEqual(aa["aString"], "theString");
    assertEqual(aa["anInt"], "42");
}
