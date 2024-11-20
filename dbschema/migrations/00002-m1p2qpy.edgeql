CREATE MIGRATION m1p2qpynecmzgo6xfirc7jsyn6gspowguzaxjcn4umq3w6nutvzqkq
    ONTO m1pt5z7pohseqt7scexs7jhl4zz52ecacppg3jms5nd6t5dc2tfula
{
  ALTER TYPE default::Primitive {
      CREATE PROPERTY namespace := ((std::str_split(.__type__.name, '::'))[1]);
  };
};
