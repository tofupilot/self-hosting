CREATE MIGRATION m14rylyh5slklxsjgnwrvjqjvykohbmua374cega2cojqiwcuwdisa
    ONTO m1bnmmaz7lgtpvgco5dyua6i6bcgfj7xr3l6u3fwev7fdexyhe65eq
{
  ALTER TYPE default::Primitive {
      DROP CONSTRAINT std::exclusive ON ((.identifier, .organization));
  };
};
