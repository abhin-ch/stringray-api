FROM mcr.microsoft.com/dotnet/sdk:8.0 as build-env
WORKDIR /app
COPY . ./
WORKDIR /app/StingrayNET.Api
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
ARG ENVNAME
ENV ASPNETCORE_ENVIRONMENT ${ENVNAME}
WORKDIR /app
EXPOSE 80
COPY --from=build-env /app/StingrayNET.Api/out .
ENTRYPOINT ["dotnet","StingrayNET.Api.dll"]