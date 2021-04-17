using System;

namespace Person
{
    record Person
    {
        // Member public but only readonly
        public readonly Guid Id = new();

        public string Name { get; set; }

        public uint Age
        {
            get => Age;
            set
            {
                if (value > 120)
                {
                    throw new ArgumentOutOfRangeException();
                }   
            }
        }
    }
}
