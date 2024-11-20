CREATE MIGRATION m17cpgfflgibdac7zc2jz75iei2zw3idqihpsw43jz45voc64faqxq
    ONTO m1yyc7iygysc7mu5e7xcrkemwir6mefnjjlhtky6b5nvxv5ghucwyq
{
  ALTER TYPE default::Issue RENAME TO default::Defect;
};
