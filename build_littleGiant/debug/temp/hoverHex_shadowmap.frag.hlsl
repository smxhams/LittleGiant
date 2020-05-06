void frag_main()
{
    float opacity = 0.099799998104572296142578125f;
    if (opacity < 1.0f)
    {
        discard;
    }
}

void main()
{
    frag_main();
}
