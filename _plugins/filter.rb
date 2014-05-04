module MyJekyllPlugins
    module Filter
        def format(input, fmt)
            fmt % input
        end

        def filesize(input, fmt = '%.1f %s')
            i = 0
            while input > 1024
                input /= 1024.0
                i += 1
            end

            suffix = ['', 'k', 'M', 'G', 'T']
            fmt % [input, suffix[i]]
        end

        def basename(input)
            File.basename(input)
        end
    end
end

Liquid::Template.register_filter(MyJekyllPlugins::Filter)
