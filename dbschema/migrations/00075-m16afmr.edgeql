CREATE MIGRATION m16afmrnf3goaxwx43ky37q6e7ptjhpt66jtkawuivq7iyammou4eq
    ONTO m126dpmwwunhiqgzro3vervqm7htib2zvlasdq3v357wu4x664c5ia
{
  ALTER TYPE default::Primitive {
      CREATE PROPERTY estimatedTime -> std::duration;
  };
};
